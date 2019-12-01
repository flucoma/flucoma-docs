#pragma once
#include <clients/common/FluidBaseClient.hpp>

#include <clients/common/SharedClientUtils.hpp>
#include <clients/nrt/DataSetClient.hpp>
#include <clients/nrt/LabelSetClient.hpp>

#include <nlohmann/json.hpp>
#include <array>
#include <fstream>
#include <string>
#include <utility>

/// This will produce JSON output of the params and messages for a Fluid Client object
/// Because we need to preserve the declared ordering of params (which turn into arguments in some hosts),
/// the output is JSON arrays: each array element is a 2 item sub-array with the name and a JSON object
/// that has the meta-data. This then turned back into an associative structure in pyton (i.e. dict(...))
/// This way we are gurranteed to preserve ordering


// for convenience
using json = nlohmann::json;

namespace fluid {
namespace client {

template<size_t...Offsets, typename...Ts>
std::index_sequence<Offsets...> parameterIndexOffsets(ParameterDescriptorSet<std::index_sequence<Offsets...>,std::tuple<Ts...>>)
{
  return {};
}

template<typename C, typename AllParams>
struct Constraint
{
  C constraint;
  AllParams allParams;
};

template<typename C, typename AllParams>
Constraint<C,AllParams> makeConstraint(C c, AllParams& p)
{
  return {c,p};
}

template<typename T>
void to_json(json& o,const Constraint<EnumT::EnumConstraint,T>&)
{
  o["enum"] = true;
}

template<typename T, int MaxFFT>
void to_json(json& o,const Constraint<FFTParams::FFTSettingsConstraint<MaxFFT>,T>&)
{
  o["MaxFFT"] =  MaxFFT > -1;
}

template<typename T, typename AllParams>
void to_json(json& o, const Constraint<impl::MinImpl<T>,AllParams>& c)
{
  o["min"] = c.constraint.value;
};

template<typename T, typename AllParams>
void to_json(json& o, const Constraint<impl::MaxImpl<T>,AllParams>& c)
{
  o["max"] = c.constraint.value;
};

template<int...Is, size_t...Offsets, typename Tuple>
std::array<const char*,sizeof...(Is)> relations(Tuple& params,std::index_sequence<Offsets...>)
{
  return {{std::get<0>(std::get<Is + std::get<Is>(std::make_tuple(Offsets...))>(params)).name...}};
}

template<typename AllParams, int...Is>
void to_json(json& o, const Constraint<impl::UpperLimitImpl<Is...>,AllParams>& c)
{
  o["upper"] = relations<Is...>(c.allParams.descriptors(),parameterIndexOffsets(c.allParams));
};

template<typename AllParams, int...Is>
void to_json(json& o, const Constraint<impl::LowerLimitImpl<Is...>,AllParams>& c)
{
  o["lower"] = relations<Is...>(c.allParams.descriptors(),parameterIndexOffsets(c.allParams));
};

template<typename AllParams,int I>
void to_json(json& o, const Constraint<impl::FrameSizeUpperLimitImpl<I>,AllParams>&)
{
  o["upper"] = "fftFrame";
};

template<typename AllParams,int I>
void to_json(json& o, const Constraint<impl::MaxFrameSizeUpperLimitImpl<I>,AllParams>&)
{
  o["upper"] = "maxFFTFrame";
};

template<typename AllParams>
void to_json(json& o, const Constraint<Odd,AllParams>&)
{
  o["snap"] = "odd";
};

template<typename AllParams>
void to_json(json& o, const Constraint<PowerOfTwo,AllParams>&)
{
  o["snap"] = "powerTwo";
};

template<typename AllParams>
void to_json(json& o, const Constraint<FrequencyAmpPairConstraint,AllParams>&)
{
  o["FreqAmpPair"] = true;
};

void to_json(json& j, const FFTParams& p)
{
    j = json::array({{"winSize", p.winSize()}, {"hopSize", p.hopRaw()}, {"fftSize", p.fftRaw()}});
}

void to_json(json& j, const FloatPairsArrayT::FloatPairsArrayType& p)
{
    j = json{{"value", p.value}};
}

template<typename Param, typename Tuple, typename AllParams>
struct ParamBundle
{
  Param p;
  Tuple tuple;
  AllParams allParams;
};

template<typename Param, typename Tuple, typename AllParams>
ParamBundle<Param,Tuple,AllParams> makeParamBundle(Param p, Tuple t,AllParams a)
{
  return {p,t,a};
}

std::string getParamType(const BufferT&) { return "buffer"; }
std::string getParamType(const InputBufferT&) { return "buffer"; }
std::string getParamType(const FloatT&) { return "float"; }
std::string getParamType(const LongT&) { return "long"; }
std::string getParamType(const FloatPairsArrayT&) { return "float";}
std::string getParamType(const StringT&) { return "symbol";}

std::string getParamType(const std::string&) { return "symbol";}

std::string getParamType(const typename BufferT::type&) { return "buffer"; }
std::string getParamType(const typename InputBufferT::type&) { return "buffer"; }

template<typename T>
std::enable_if_t<std::is_integral<T>::value, std::string>
getParamType(const T&) { return "long"; }

template<typename T>
std::enable_if_t<std::is_floating_point<T>::value, std::string>
getParamType(const T&) { return "float"; }

std::string getParamType(const DataSetClientRef&) { return "dataset"; }
std::string getParamType(const LabelSetClientRef&) { return "labelset"; }

template<typename T>
std::string getParamType(const FluidTensor<T,1>&) { return "array " + getParamType(T{}); }


template<typename...Ts,size_t...Is>
auto getParamType(const std::tuple<Ts...>&, std::index_sequence<Is...>){
  std::array<std::string, sizeof...(Ts)> res{{getParamType(std::add_const_t<std::tuple_element_t<Is,std::tuple<Ts...>>>{})...}};
  return res;
}

template<typename...Ts>
auto getParamType(const std::tuple<Ts...>& t)
{
  return getParamType(t,std::index_sequence_for<Ts...>());
}

template<typename T>
std::string getParamType(const MessageResult<T>&)
{
  return getParamType(typename MessageResult<T>::type{});
}

std::string getParamType(const MessageResult<void>&)
{
  return "void";
}

template<typename ConstraintsTuple, typename ParamsTuple, size_t...Is>
std::array<json, sizeof...(Is)> constraints(ConstraintsTuple cs, ParamsTuple ps, std::index_sequence<Is...>)
{
  return {{makeConstraint(std::get<Is>(cs),ps)...}};
}

template<typename Param, typename Tuple, typename AllParams>
void to_json(json& o, const ParamBundle<Param,Tuple,AllParams>& pb)
{
    auto& p = pb.p;
    constexpr bool fixed = std::tuple_element<2,Tuple>::type::value;
    json j({});
    j["displayName"] = p.displayName;
    j["default"] = p.defaultValue;
    j["fixed"] = fixed;
    j["type"] = getParamType(p);
    j["size"] = p.fixedSize;
  
  
    //constraints
    auto& constraintsTuple = std::get<1>(pb.tuple);
    using constraintsTupleType = std::decay_t<decltype(constraintsTuple)>;
    constexpr size_t numConstraints = std::tuple_size<constraintsTupleType>::value;
    if(numConstraints > 0)
    {
      auto constraintsIndex = std::make_index_sequence<numConstraints>();
      auto c = constraints(constraintsTuple,pb.allParams,constraintsIndex);
      j["constraints"] = c;
    }
    o = {p.name, j};
}

template<typename Tuple, typename AllParams>
void to_json(json& o, const ParamBundle<EnumT,Tuple,AllParams>& pb)
{
  auto& p = pb.p;
  json j;
  j["displayName"] = p.displayName;
  j["default"] = p.defaultValue;
  j["fixed"] = false;
  j["size"] = 1;
  std::vector<std::string> strings(p.numOptions);
  std::copy(p.strings, p.strings + p.numOptions,strings.begin());
  j["values"] = strings;
  j["type"] = "enum";
  o = {p.name, j};
}

template<typename Tuple, typename AllParams>
void to_json(json& o, const ParamBundle<FFTParamsT,Tuple,AllParams>& pb)
{
  auto& p = pb.p;
  json j;
  j["displayName"] = p.displayName;
  j["default"] = p.defaultValue;
  j["fixed"] = false;
  j["size"] = 3;
  j["type"] = "long";
  o = {p.name, j};
}

template<typename L, typename Ret, typename T, typename...Args>
void to_json(json& o, const Message<L,Ret,T,Args...>& m)
{
  json j;
  j["return"] = getParamType(Ret{});
  j["args"] = getParamType(std::tuple<Args...>{});
  o = {m.name,j};
}

template <class T>
class ParameterDump
{
public:
  using  Params = typename ClientWrapper<T>::ParamDescType;
  using  Messages = typename T::MessageSetType;

  static void dump(std::string ofile,std::string prefix)
  {
    json j;
    j["params"]= dumpParams(typename Params::IndexList());
    j["messages"] = dumpMessages(typename Messages::IndexList());
    std::ofstream(prefix + ofile + ".json") << j.dump(2) << '\n';
  }

  template<size_t...Is>
  static json dumpParams(std::index_sequence<Is...>)
  {
    Params& p = ClientWrapper<T>::getParameterDescriptors();
    auto d = p.descriptors();
    return json::array_t{makeParamBundle(std::get<0>(std::get<Is>(d)),std::get<Is>(d),p)...};
  }
  
  template<size_t...Is>
  static json dumpMessages(std::index_sequence<Is...>)
  {
    const auto m = T::getMessageDescriptors();
    return json::array_t{m.template get<Is>()...};
  }
};

}
}
